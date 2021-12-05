# frozen_string_literal: true

require_relative '../../../step/special_choose'

module Engine
  module Game
    module G1822MX
      module Step
        class SpecialChoose < Engine::Step::SpecialChoose
          def process_choose_ability(action)
            if action.choice == 'close_p16'
              @log << "#{action.entity.owner.name} chooses to close P16"
              @game.close_p16
            end
          end

        end
      end
    end
  end
end
