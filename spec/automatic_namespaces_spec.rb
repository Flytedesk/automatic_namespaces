require "pathname"

rails_dir = Pathname.new(File.expand_path("fixtures/rails-7.0", __dir__))
Dir.chdir(rails_dir)
require_relative rails_dir.join("config/environment") # boot rails here

RSpec.describe AutomaticNamespaces do

  it "creates a namespace for each pack" do
    expect(defined?(Jackets)).to eq("constant")
    expect(defined?(Pants)).to eq("constant")
    expect(defined?(Shirts)).to eq("constant")
    expect(defined?(ShoesUI)).to eq("constant")
    expect(defined?(Hats::Summer)).to eq("constant")
    expect(defined?(Hats::Winter)).to eq("constant")
  end

  it 'can find classes that ARE in an automatic namespace pack' do
    expect(defined?(Jackets::ClothingController)).to eq("constant")
    expect(defined?(Jackets::Summer)).to eq("constant")
    expect(defined?(Jackets::Winter)).to eq("constant")
    expect(defined?(Jackets::PriceStrategy::SalePrice)).to eq("constant")
    expect(defined?(Jackets::PriceStrategy::VolumePrice)).to eq("constant")
  end

  it 'can find classes that are NOT in an automatic namespace pack' do
    expect(defined?(Pants::Jeans)).to eq("constant")
  end

  it 'can find classes that are in an automatic namespace pack which use namespace override' do
    expect(defined?(ShoesUI::Sneakers)).to eq("constant")
  end

  it 'can find classes that are in an automatic namespace pack which use namespace override' do
    expect(defined?(ShoesUI::Sneakers)).to eq("constant")
  end

  it 'can find classes that are in an automatic namespace pack which use nested namespace override' do
    expect(defined?(Hats::Summer::BaseballCap)).to eq("constant")
    expect(defined?(Hats::Winter::WoolBeanie)).to eq("constant")
  end

  it "doesn't crash when a package yml is corrupted" do
    expect(defined?(Shirts::Tshirt)).to eq("constant")
  end

  it 'excludes helpers from automatic namespacing' do
    expect(defined?(ShirtHelper)).to eq("constant")
  end

  context 'when automatic_namespaces_exclusions is provided' do
    it 'does not add the namespace to files in those directories' do
      expect(defined?(Sneaker)).to eq("constant")
    end
  end

  it "can find classes that are located at the root of the package.yml" do
    expect(defined?(Summer::Fun)).to eq("constant")
    expect(defined?(Summer::Swim)).to eq("constant")
    expect(defined?(Summer::Swim::Trunks)).to eq("constant")
  end
end
