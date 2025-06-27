# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Enforce the usage of `::` in front of any Ruby constant to ensure
      # constants are resolved from the root namespace.
      # Excludes Ruby standard library constants.
      #
      # @example RequireConstantPrefix:
      #
      #   # bad
      #   MyClass::CONSTANT
      #   SomeModule.method
      #   CustomClass.new
      #
      #   # good
      #   String.new  # Ruby stdlib - allowed
      #   Array.new   # Ruby stdlib - allowed
      #   ::MyClass::CONSTANT
      #   ::SomeModule.method
      #   ::CustomClass.new
      #
      class RequireConstantPrefix < Base
        extend AutoCorrector

        MSG = 'Use `::` prefix for constants to ensure resolution from root namespace.'

        # Ruby standard library constants that should be excluded from this rule
        RUBY_STDLIB_CONSTANTS = %w[
          Array BasicObject Binding Class Complex Data Dir Encoding Enumerator
          Exception FalseClass File Float Hash Integer IO Kernel MatchData Method
          Module NilClass Numeric Object Proc Range Rational Regexp String
          Struct Symbol Thread Time TrueClass UnboundMethod
          Comparable Enumerable Math FileTest Marshal ObjectSpace Process
          GC Signal Fiber Random SecureRandom Set OpenStruct Pathname
          URI JSON CSV YAML Zlib Digest Base64 Logger Benchmark
          Date DateTime BigDecimal StringIO Tempfile
        ].freeze

        def on_const(node)
          return if prefixed_with_double_colon?(node)
          return if nested_constant?(node)
          return if ruby_stdlib_constant?(node)

          add_offense(node) do |corrector|
            full_constant_name = resolve_constant_namespace(node)
            if full_constant_name && full_constant_name != node.const_name
              corrector.replace(node, full_constant_name)
            else
              corrector.insert_before(node, '::')
            end
          end
        end

        private

        def prefixed_with_double_colon?(node)
          node.source.start_with?('::')
        end

        def nested_constant?(node)
          # Don't flag constants that are already nested within another constant
          # e.g., in MyClass::CONSTANT, we only want to flag MyClass, not CONSTANT
          parent = node.parent
          return false unless parent

          parent.const_type? && parent.children.last == node
        end

        def ruby_stdlib_constant?(node)
          RUBY_STDLIB_CONSTANTS.include?(node.const_name)
        end

        def resolve_constant_namespace(node)
          constant_name = node.const_name
          current_namespace = find_current_namespace(node)

          # Try to find the constant definition in the current file
          constant_definition = find_constant_definition(constant_name, current_namespace)

          if constant_definition
            build_full_namespace_path(constant_definition)
          else
            nil
          end
        end

        def find_current_namespace(node)
          namespaces = []
          current = node

          while current
            case current.type
            when :class, :module
              if current.children.first.const_type?
                namespace_name = build_namespace_name(current.children.first)
                namespaces.unshift(namespace_name) if namespace_name
              end
            end
            current = current.parent
          end

          namespaces
        end

        def build_namespace_name(const_node)
          case const_node.type
          when :const
            if const_node.children.first.nil?
              # Top-level constant like ::MyClass
              const_node.const_name
            elsif const_node.children.first.const_type?
              # Nested constant like MyModule::MyClass
              "#{build_namespace_name(const_node.children.first)}::#{const_node.const_name}"
            else
              const_node.const_name
            end
          when :cbase
            nil
          else
            nil
          end
        end

        def find_constant_definition(constant_name, current_namespace)
          # Get the root node of the AST
          root_node = find_root_node
          return nil unless root_node

          # Search for constant definitions
          find_constant_in_node(root_node, constant_name, current_namespace)
        end

        def find_root_node
          processed_source&.ast
        end

        def find_constant_in_node(node, constant_name, current_namespace, search_namespace = [])
          return nil unless node.is_a?(AST::Node)

          case node.type
          when :class, :module
            # Extract the namespace name
            namespace_node = node.children.first
            if namespace_node&.const_type?
              namespace_name = build_namespace_name(namespace_node)
              new_search_namespace = search_namespace + [namespace_name].compact

              # Check if this is the constant we're looking for
              if namespace_name == constant_name
                # Check if we're in the right context
                if namespaces_match?(current_namespace, search_namespace)
                  return new_search_namespace
                end
              end

              # Search within this namespace
              result = search_children(node, constant_name, current_namespace, new_search_namespace)
              return result if result
            end
          when :casgn
            # Constant assignment like CONSTANT = value
            if node.children[1] == constant_name.to_sym
              full_namespace = search_namespace + [constant_name]
              if namespaces_match?(current_namespace, search_namespace)
                return full_namespace
              end
            end
          end

          # Search children nodes
          search_children(node, constant_name, current_namespace, search_namespace)
        end

        def search_children(node, constant_name, current_namespace, search_namespace)
          node.children.each do |child|
            result = find_constant_in_node(child, constant_name, current_namespace, search_namespace)
            return result if result
          end
          nil
        end

        def namespaces_match?(current_namespace, search_namespace)
          # Allow matching if we're in the same namespace or a parent namespace
          return true if search_namespace.empty?
          return true if current_namespace.empty?

          # Check if current_namespace starts with search_namespace
          search_namespace.each_with_index do |ns, index|
            return false if current_namespace[index] != ns
          end
          true
        end

        def build_full_namespace_path(namespace_parts)
          return nil if namespace_parts.empty?
          "::#{namespace_parts.join('::')}"
        end
      end
    end
  end
end
