# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../player'
require_relative '../game'

# Each player will select multiple certs to keep from intial hand
# Selections and hands should be kept hidden from other players
module Engine
  module Game
    module G18India
      module Step
        class CertificateSelection < Engine::Step::Base
          attr_reader :choices

          ACTIONS = %w[select_multiple_companies].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] if finished?

            ACTIONS
          end

          def setup
            @choices = Hash.new { |h, k| h[k] = [] }
            @cards_to_keep = @game.certs_to_keep
            @confirmed_selections = 0
          end

          def pass_description
            'Complete Selection'
          end

          def available
            current_entity.hand.sort.reverse
          end

          def may_purchase?(_company)
            false
          end

          def may_choose?(_company)
            false
          end

          def auctioning; end

          def bids
            {}
          end

          def visible?
            false
          end

          def players_visible?
            false
          end

          def show_companies
            true
          end

          def show_map
            true
          end

          def name
            'Initial Hand Selection'
          end

          def description
            "Select #{@cards_to_keep} Certificates for your starting hand"
          end

          def selection_note
            [
              "Made #{number_of_selections} of #{@cards_to_keep} selections.",
              'Click on card to select or unselect it.',
            ]
          end

          def select_company(player, company)
            return if selections_completed? && company.owner.nil? # prevent selecting more than allowed

            # add or remove from choices
            if company_selected?(company)
              @choices[player].delete(company)
              company.owner = nil
            else
              @choices[player] << company
              @choices[player].sort!
              company.owner = player
            end
          end

          def company_selected?(company)
            @choices[current_entity].include?(company)
          end

          def selected_companies
            @choices[current_entity]
          end

          def number_of_selections
            selected_companies.size
          end

          def selections_completed?
            number_of_selections == @cards_to_keep
          end

          def process_select_multiple_companies(action)
            player = action.entity
            selected_companies = action.companies
            @log << "#{player.name} selected #{selected_companies.size} certificates for hand"
            selected_companies.each { |company| company.owner = player }
            unselected_companies = player.hand - selected_companies
            unselected_companies.each { |company| company.owner = nil }
            @confirmed_selections += 1
            LOGGER.debug " Test  Process Muti-Select => confirmed_selections: #{@confirmed_selections} finished?: #{finished?}  "\
                         "selected: #{selected_companies.inspect} unselected: #{unselected_companies.inspect}"
            @round.next_entity_index!
            action_finalized
          end

          def finished?
            @confirmed_selections == @game.players.size
          end

          def action_finalized
            return unless finished?

            @log << 'Inital hand selections completed'
            @game.prepare_draft_deck
          end

          def committed_cash(_player, _show_hidden)
            0
          end
        end
      end
    end
  end
end
