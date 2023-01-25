# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1880
      module Step
        class Choose < Engine::Step::Base
          ACTIONS = %w[choose pass].freeze

          def actions(_entity)
            return [] unless award_company

            ACTIONS
          end

          def auto_actions(entity)
            return [Engine::Action::Choose.new(entity, choice: '')] if @game.phase.name == 'B2'

            []
          end

          def active_entities
            [award_company]
          end

          def active?
            award_company
          end

          def choice_name
            return "Receive #{@game.p0.name} payment?" if @company

            'Choose'
          end

          def choices
            return ["Receive #{@game.p0.name} payment of #{@game.format_currency(sell_price)}"] if @company

            {}
          end

          def round_state
            super.merge(
            { already_passed: false }
          )
          end

          def description
            "#{@game.p0.name} payment"
          end

          def process_choose(action)
            action.entity.owner.companies.delete(@company)
            @game.bank.spend(sell_price, @company.owner) if sell_price.positive?
            @company.close!
            @log << "#{action.entity.name} receives #{@game.format_currency(sell_price)} one-time payment from #{@company.name}"
            @company = nil
            pass!
          end

          def hide_corporations?
            true
          end

          def choice_available?(_entity)
            true
          end

          def skip!
            pass!
          end

          def can_receive_payment?
            @game.class::P0_AWARD.key?(@game.phase.name) && !@game.p0.closed?
          end

          def award_company
            @company = @game.p0
            return nil if !@company || !can_receive_payment? || @round.already_passed

            @company
          end

          def sell_price
            @game.class::P0_AWARD[@game.phase.name]
          end

          def process_pass(action)
            super
            @round.already_passed = true
          end
        end
      end
    end
  end
end
