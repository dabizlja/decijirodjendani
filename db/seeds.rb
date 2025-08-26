# Create the 6 main categories
categories = [
  {
    name: "Restorani",
    slug: "restorani",
    description: "Restorani pogodni za dečje rođendane sa posebnim menijima i prostorima",
    icon: "🍽️",
    color: "bg-purple-500",
    active: true
  },
  {
    name: "Igraonice",
    slug: "igraonice",
    description: "Zatvorene igraonice sa raznovrsnim aktivnostima za decu",
    icon: "🎪",
    color: "bg-pink-500",
    active: true
  },
  {
    name: "Animatori",
    slug: "animatori",
    description: "Profesionalni animatori za nezaboravne rođendanske zabave",
    icon: "🎭",
    color: "bg-yellow-500",
    active: true
  },
  {
    name: "Rođendanske Torte",
    slug: "torte",
    description: "Slastičarnice i pekare specijalizovane za rođendanske torte",
    icon: "🎂",
    color: "bg-blue-500",
    active: true
  },
  {
    name: "Dekoracije",
    slug: "dekoracije",
    description: "Kompletne dekoracije za tematske rođendanske zabave",
    icon: "🎈",
    color: "bg-green-500",
    active: true
  },
  {
    name: "Ketering",
    slug: "ketering",
    description: "Ketering servisi specijalizovani za dečje rođendane sa zdravom hranom",
    icon: "🍱",
    color: "bg-indigo-500",
    active: true
  }
]

categories.each do |category_attrs|
  Category.find_or_create_by(slug: category_attrs[:slug]) do |category|
    category.assign_attributes(category_attrs)
  end
end

puts "Created #{Category.count} categories"

# Create the main cities
cities = [
  {
    name: "Beograd",
    slug: "beograd",
    region: "Centralna Srbija",
    active: true
  },
  {
    name: "Novi Sad",
    slug: "novi-sad",
    region: "Vojvodina",
    active: true
  },
  {
    name: "Niš",
    slug: "nis",
    region: "Južna Srbija",
    active: true
  },
  {
    name: "Kragujevac",
    slug: "kragujevac",
    region: "Centralna Srbija",
    active: true
  },
  {
    name: "Kruševac",
    slug: "krusevac",
    region: "Centralna Srbija",
    active: true
  },
  {
    name: "Kraljevo",
    slug: "kraljevo",
    region: "Centralna Srbija",
    active: true
  }
]

cities.each do |city_attrs|
  City.find_or_create_by(slug: city_attrs[:slug]) do |city|
    city.assign_attributes(city_attrs)
  end
end

puts "Created #{City.count} cities"
