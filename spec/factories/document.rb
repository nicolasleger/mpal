FactoryGirl.define do
  factory :document do
    projet
    label "Titre de propriété"
    fichier { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/Ma pièce jointe.txt'))) }
  end
end
