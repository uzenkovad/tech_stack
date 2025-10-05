class Ingredient
  attr_reader :name, :unit, :calories_per_unit

  def initialize(name, unit, calories_per_unit)
    @name = name
    @unit = unit
    @calories_per_unit = calories_per_unit
  end
end

class Recipe
  attr_reader :name, :steps, :items

  def initialize(name, steps = [], items = [])
    @name = name
    @steps = steps
    @items = items
  end

  # Повертає кількість інгредієнтів у базових одиницях
  def need
    result = {}
    @items.each do |item|
      base_qty = UnitConverter.to_base(item[:qty], item[:unit])
      result[item[:ingredient].name] = base_qty
    end
    result
  end
end

class Pantry
  def initialize
    @storage = {}
  end

  def add(name, qty, unit)
    base_qty = UnitConverter.to_base(qty, unit)
    @storage[name] ||= 0
    @storage[name] += base_qty
  end

  def available_for(name)
    @storage[name] || 0
  end
end

module UnitConverter
  def self.to_base(qty, unit)
    case unit
    when :kg then qty * 1000
    when :g then qty
    when :l then qty * 1000
    when :ml then qty
    when :pcs then qty
    else
      raise "Unknown unit #{unit}"
    end
  end
end

class Planner
  def self.plan(recipes, pantry, price_list)
    total_need = {}
    total_calories = 0
    total_cost = 0

    # Рахуємо сумарну потребу по інгредієнтах
    recipes.each do |recipe|
      recipe.need.each do |name, qty|
        total_need[name] ||= 0
        total_need[name] += qty
      end
    end

    total_need.each do |name, needed_qty|
      have_qty = pantry.available_for(name)
      deficit = [needed_qty - have_qty, 0].max
      unit_price = price_list[name][:price]
      calories_per_unit = price_list[name][:calories]

      total_calories += needed_qty * calories_per_unit
      total_cost += needed_qty * unit_price

      puts "#{name}: потрібно #{needed_qty} / є #{have_qty} / дефіцит #{deficit}"
    end

    puts "Total calories: #{total_calories.round(2)}"
    puts "Total cost: #{total_cost.round(2)}"
  end
end

# Приклад використання
flour = Ingredient.new("борошно", :g, 3.64)
milk = Ingredient.new("молоко", :ml, 0.06)
egg = Ingredient.new("яйце", :pcs, 72)
pasta = Ingredient.new("паста", :g, 3.5)
sauce = Ingredient.new("соус", :ml, 0.2)
cheese = Ingredient.new("сир", :g, 4.0)

omelet = Recipe.new("Омлет", [], [
  { ingredient: egg, qty: 3, unit: :pcs },
  { ingredient: milk, qty: 100, unit: :ml },
  { ingredient: flour, qty: 20, unit: :g }
])

pasta_recipe = Recipe.new("Паста", [], [
  { ingredient: pasta, qty: 200, unit: :g },
  { ingredient: sauce, qty: 150, unit: :ml },
  { ingredient: cheese, qty: 50, unit: :g }
])

pantry = Pantry.new
pantry.add("борошно", 1, :kg)
pantry.add("молоко", 0.5, :l)
pantry.add("яйце", 6, :pcs)
pantry.add("паста", 300, :g)
pantry.add("сир", 150, :g)

price_list = {
  "борошно" => { price: 0.02, calories: 3.64 },
  "молоко" => { price: 0.015, calories: 0.06 },
  "яйце" => { price: 6.0, calories: 72 },
  "паста" => { price: 0.03, calories: 3.5 },
  "соус" => { price: 0.025, calories: 0.2 },
  "сир" => { price: 0.08, calories: 4.0 }
}

Planner.plan([omelet, pasta_recipe], pantry, price_list)
