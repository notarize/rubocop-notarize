# frozen_string_literal: true

module RuboCop
    module Cop
      module Swagger
        class CheckForErrorDocumentation < Base
          MSG = 'Swagger documentation missing'.freeze
          SPEC_PATH_BASE = 'spec/requests/external_api'.freeze
          
          # need to better understand _method_name
          # I could only get this to match a single instance of render_error for each method
          def_node_matcher :search_for_render_error, <<~PATTERN
            (def $_method_name _args `(send nil? :render_error _ _))
          PATTERN

          def_node_matcher :method_name, <<~PATTERN
            (def $_method_name ...)
          PATTERN
          
          def on_new_investigation
            @current_file_path = file_path_from_corrector(@current_corrector)
            @current_spec_path = spec_path_from_current_path(@current_file_path)
            @invalid_spec_code = false
            @missing_spec_file = false

            unless File.file?(@current_spec_path)
              add_global_offense("Missing spec file.")
              @missing_spec_file = true
              return
            end
            
            @spec_source = RuboCop::ProcessedSource.new(File.read(@current_spec_path), RUBY_VERSION.to_f)

            unless @spec_source.valid_syntax?
              add_global_offense("Unable to parse spec file - incorrect syntax.")
              @invalid_spec_code = true
              return
            end
            @spec_nodes = @spec_source.ast
          end
  
          def on_def(nodes)
            # Return if there isn't any render_error functions or if spec is malformed
            # Currently has the limitation that if 'render_error' is not in the method, then it wont check for 200
            return if @invalid_spec_code || @missing_spec_file
            return unless search_for_render_error(nodes) 

            method_name = method_name(nodes)
            render_errors = []
            spec_definitions = []

            # Since I can't seem to target multiple render_error functions with the pattern above, we are going
            # to tree through the node instead.
            nodes.each_descendant do |node|
              next unless node.class == RuboCop::AST::SendNode
              next unless node.method_name == :render_error
              render_errors << node.child_nodes.first.value
            end

            return if render_errors == []
            
            # This could be made more efficient if I can figure out how to take an individual node and 
            # use it to start a new node  tree with just the section of the spec I care about
            found_test = false

            @spec_nodes.each_descendant do |spec_node|
              # This executes till we find the test for our specific method_name
              next unless spec_node.class == RuboCop::AST::SendNode
              unless found_test
                next unless spec_node.method_name == :path
                path_str = spec_node.child_nodes.first.value
                if path_str.split('/').include? method_name.to_s
                  found_test = true
                end
                next
              end

              # We've found the test we care about, so now we are looking for response methods
              # Keep checking for path and break out if we find it as that mean's we've moved onto
              # the next test.
              next unless spec_node.method_name == :response || spec_node.method_name == :path
              if spec_node.method_name == :path
                break
              end

              spec_definitions << spec_node.child_nodes.first.value
            end

            # Check for a 200 definition
            render_errors << :ok

            render_errors.each do |error_def|
              next if error_def == :internal_server_error
              status_code = status_symbol_to_status_code(error_def)
              unless spec_definitions.include? status_code
                add_global_offense("Could not find a test for #{method_name} :: #{error_def}/#{status_code}")
              end
            end
          end

          # Need to research more to make sure this works appropriate through checksum caching
          def external_dependency_checksum
            true
          end

          private

          def file_path_from_corrector(corrector)
            # Ex: "#<RuboCop::Cop::Corrector /notarize/notarize-api/app/controllers/external_api/real_estate_api/eligibilities_controller.rb: empty>"
            corrector.inspect.split('/')[1...].join('/').split(':').first
          end

          def spec_path_from_current_path(path)
            # Ex: "/notarize/notarize-api/app/controllers/external_api/real_estate_api/eligibilities_controller.rb"
            path_segments = path.split('/')
            spec_name = "#{path_segments.last.split('_').first}_spec.rb"
            "#{SPEC_PATH_BASE}/#{path_segments[-2]}/#{spec_name}"
          end

          def status_symbol_to_status_code(status_symbol)            
            case status_symbol
            when :ok
              200
            when :not_found
              404
            when :bad_request
              400
            when :forbidden
              403
            when :unprocessable_entity
              422
            when :internal_server_error
              0
            end
          end
        end
      end
    end
  end
  