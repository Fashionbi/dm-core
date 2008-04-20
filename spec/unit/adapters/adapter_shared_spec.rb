
describe "a DataMapper Adapter", :shared => true do

  it "should initialize the connection uri" do
    new_adapter = @adapter.class.new(:default, URI.parse('some://uri/string'))
    new_adapter.instance_variable_get('@uri').to_s.should == URI.parse('some://uri/string').to_s
  end

  %w{create read update delete read_one read_set delete_set create_model_storage alter_model_storage destroy_model_storage create_property_storage alter_property_storage destroy_property_storage} .each do |meth|
    it "should have a #{meth} method" do
      @adapter.should respond_to(meth.intern)
    end
  end

end
