FactoryBot.define do
  factory :article do
    title {Faker::Games::WorldOfWarcraft.hero}
    body {Faker::JapaneseMedia::Naruto.character + ' ' + Faker::Music::Hiphop.artist + ' ' + Faker::Games::Dota.item}
  end
end