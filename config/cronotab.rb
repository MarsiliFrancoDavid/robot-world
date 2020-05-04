require 'rake'

Rails.app_class.load_tasks

class StartProduction
  def perform
    Rake::Task['robot_builder:start_production'].execute
  end
end

class MoveCarsFromFactoryToStoreStock
    def perform
      Rake::Task['guard_robot:move_cars_from_factory_to_store_stock'].execute
    end
end
  
class BuyCars
    def perform
      Rake::Task['robot_buyer:buy_cars'].execute
    end
end

class ExchangeCars
    def perform
      Rake::Task['robot_buyer:exchange_cars'].execute
    end
end

class GenerateStatistics
    def perform
      Rake::Task['exec_robot:generate_business_statistics'].execute
    end
end

class Cleanup
    def perform
      Rake::Task['robot_builder:cleanup'].execute
    end
end




Crono.perform(StartProduction).every 20.seconds
Crono.perform(MoveCarsFromFactoryToStoreStock).every 30.seconds
Crono.perform(BuyCars).every 30.seconds
Crono.perform(ExchangeCars).every 30.seconds
Crono.perform(GenerateStatistics).every 1.minute
Crono.perform(Cleanup).every 5.minutes