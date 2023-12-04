# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for self-assignments.
      #
      # @example
      #   # bad
      #   foo = foo
      #   foo, bar = foo, bar
      #   Foo = Foo
      #   hash['foo'] = hash['foo']
      #   obj.attr = obj.attr
      #
      #   # good
      #   foo = bar
      #   foo, bar = bar, foo
      #   Foo = Bar
      #   hash['foo'] = hash['bar']
      #   obj.attr = obj.attr2
      #
      #   # good (method calls possibly can return different results)
      #   hash[foo] = hash[foo]
      #
      class SelfAssignment < Base
        MSG = 'Self-assignment detected.'

        ASSIGNMENT_TYPE_TO_RHS_TYPE = {
          lvasgn: :lvar,
          ivasgn: :ivar,
          cvasgn: :cvar,
          gvasgn: :gvar
        }.freeze

        def on_send(node)
          if node.method?(:[]=)
            handle_key_assignment(node) if node.arguments.size == 2
          elsif node.assignment_method?
            handle_attribute_assignment(node) if node.arguments.size == 1
          end
        end
        alias on_csend on_send

        def on_lvasgn(node)
          lhs, rhs = *node
          return unless rhs

          rhs_type = ASSIGNMENT_TYPE_TO_RHS_TYPE[node.type]

          add_offense(node) if rhs.type == rhs_type && rhs.source == lhs.to_s
        end
        alias on_ivasgn on_lvasgn
        alias on_cvasgn on_lvasgn
        alias on_gvasgn on_lvasgn

        def on_casgn(node)
          lhs_scope, lhs_name, rhs = *node
          return unless rhs&.const_type?

          rhs_scope, rhs_name = *rhs
          add_offense(node) if lhs_scope == rhs_scope && lhs_name == rhs_name
        end

        def on_masgn(node)
          add_offense(node) if multiple_self_assignment?(node)
        end

        def on_or_asgn(node)
          lhs, rhs = *node
          add_offense(node) if rhs_matches_lhs?(rhs, lhs)
        end
        alias on_and_asgn on_or_asgn

        private

        def multiple_self_assignment?(node)
          lhs, rhs = *node
          return false unless rhs.array_type?
          return false unless lhs.children.size == rhs.children.size

          lhs.children.zip(rhs.children).all? do |lhs_item, rhs_item|
            rhs_matches_lhs?(rhs_item, lhs_item)
          end
        end

        def rhs_matches_lhs?(rhs, lhs)
          rhs.type == ASSIGNMENT_TYPE_TO_RHS_TYPE[lhs.type] &&
            rhs.children.first == lhs.children.first
        end

        def handle_key_assignment(node)
          value_node = node.arguments[1]

          if value_node.send_type? && value_node.method?(:[]) &&
             node.receiver == value_node.receiver &&
             !node.first_argument.call_type? &&
             node.first_argument == value_node.first_argument
            add_offense(node)
          end
        end

        def handle_attribute_assignment(node)
          first_argument = node.first_argument

          if first_argument.call_type? &&
             node.receiver == first_argument.receiver &&
             first_argument.method_name.to_s == node.method_name.to_s.delete_suffix('=')
            add_offense(node)
          end
        end
      end
    end
  end
end
