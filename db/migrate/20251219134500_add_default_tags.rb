class AddDefaultTags < ActiveRecord::Migration[7.2]
  def up
    tags_data = [
      # Venue types
      { name: "Igraonica", icon: "🎪", color: "bg-purple-500" },
      { name: "Restoran", icon: "🍽️", color: "bg-red-500" },
      { name: "Parк", icon: "🌳", color: "bg-green-500" },
      { name: "Sala za proslave", icon: "🏛️", color: "bg-blue-500" },
      { name: "Bazen", icon: "🏊", color: "bg-cyan-500" },
      { name: "Dvorana", icon: "🏢", color: "bg-gray-500" },

      # Age groups
      { name: "0-2 godine", icon: "👶", color: "bg-pink-500" },
      { name: "2-5 godina", icon: "🧒", color: "bg-yellow-500" },
      { name: "5-8 godina", icon: "👦", color: "bg-orange-500" },
      { name: "8-12 godina", icon: "👧", color: "bg-indigo-500" },
      { name: "12+ godina", icon: "🧑", color: "bg-purple-600" },

      # Services
      { name: "Hrana uključena", icon: "🍕", color: "bg-red-400" },
      { name: "Animatori", icon: "🎭", color: "bg-pink-400" },
      { name: "Muzika", icon: "🎵", color: "bg-purple-400" },
      { name: "Torta", icon: "🎂", color: "bg-yellow-400" },
      { name: "Dekoracije", icon: "🎈", color: "bg-blue-400" },
      { name: "Poklon paketići", icon: "🎁", color: "bg-green-400" },
      { name: "Foto/Video", icon: "📸", color: "bg-gray-400" },

      # Features
      { name: "Parking", icon: "🚗", color: "bg-slate-500" },
      { name: "Pristup za kolica", icon: "♿", color: "bg-teal-500" },
      { name: "Klimatizovano", icon: "❄️", color: "bg-sky-500" },
      { name: "WiFi", icon: "📶", color: "bg-violet-500" },
      { name: "Terasa", icon: "🏖️", color: "bg-amber-500" },

      # Special themes
      { name: "Princeza tema", icon: "👑", color: "bg-pink-600" },
      { name: "Superhero tema", icon: "🦸", color: "bg-red-600" },
      { name: "Safari tema", icon: "🦁", color: "bg-orange-600" },
      { name: "Piratska tema", icon: "🏴‍☠️", color: "bg-gray-600" },
      { name: "Frozen tema", icon: "❄️", color: "bg-blue-600" }
    ]

    tags_data.each do |tag_attrs|
      Tag.find_or_create_by(name: tag_attrs[:name]) do |tag|
        tag.icon = tag_attrs[:icon]
        tag.color = tag_attrs[:color]
      end
    end
  end

  def down
    # Remove the default tags (optional)
    tag_names = [
      "Igraonica", "Restoran", "Parк", "Sala za proslave", "Bazen", "Dvorana",
      "0-2 godine", "2-5 godina", "5-8 godina", "8-12 godina", "12+ godina",
      "Hrana uključena", "Animatori", "Muzika", "Torta", "Dekoracije",
      "Poklon paketići", "Foto/Video", "Parking", "Pristup za kolica",
      "Klimatizovano", "WiFi", "Terasa", "Princeza tema", "Superhero tema",
      "Safari tema", "Piratska tema", "Frozen tema"
    ]

    Tag.where(name: tag_names).destroy_all
  end
end