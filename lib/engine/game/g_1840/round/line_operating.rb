# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1840
      module Round
        class LineOperating < Engine::Round::Operating
          def select_entities
            @game.operating_order.select { |item| item.type == :minor }
          end
        end
      end
    end
  end
end
