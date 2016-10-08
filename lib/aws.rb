module Aws
  require 'time'
  #a init method to be used for initialisation when the rails application start
  def self.init
    @@dynamo_table = false
    @@dynamo_db = false
    if AWS_SETTINGS["aws_dynamo"]
      @@dynamo_db = Aws::DynamoDB::Client.new(AWS_SETTINGS["aws_dynamo"])
    end
  end

  #the method that save in aws database
  def self.save_records_to_db(params)
    return if !@@dynamo_db
    #set the table name, hash_key and range_key from the AmazonDB
    # @@dynamo_table = @@dynamo_db.list_tables.first
    # @@dynamo_table.hash_key = [:member_id, :number]
    # @@dynamo_table.range_key = [:datetime, :string]
    fields = {
      'member_id' => 1, #primary partition key
      'datetime' => Time.now.utc.iso8601, #primary sort key
    }
    fields.merge!(params[:custom_fields]) if params[:custom_fields]
    puts "fields are #{fields.inspect}"
    # @@dynamo_table.items.create(fields)
    response = @@dynamo_db.put_item({
                           table_name: "records", # required
      item: { # required
            'member_id' => 1,
            'datetime' => Time.now.utc.iso8601,
            'name' => fields['name'],
            'message' => fields['message'],
            'email' => fields['email']
      }})
    puts "response from put_itme is #{response.inspect}"
  end

  def self.get_records_from_db
    all_tables = @@dynamo_db.list_tables
    my_table = all_tables.table_names.first
    response = @@dynamo_db.scan(table_name: my_table)
    items = response.items
    puts "ITEMS IS: #{items.inspect}"
    items
  end

  def self.get_table_info
    return if !@@dynamo_db

    @@dynamo_db.list_tables
  end

  def self.delete_item(datetime, member_id)
    # result = @@dynamo_db.get_item({
    #   table_name: 'records',
    #   key: {
    #     'member_id' => member_id,
    #     'datetime' => datetime
    #   }})
    # puts "#" * 50
    # puts "items are equal? #{item == result}"
    # puts "#" * 50
    all_tables = @@dynamo_db.list_tables
    my_table = all_tables.table_names.first

    params = {
        table_name: my_table,
        key: {
            'member_id' => member_id,
            'datetime' => datetime
        }
    }

    puts "** PARAMS LOOK LIKE: #{params} **"

    response = @@dynamo_db.delete_item(params)
    puts "RESPONSE IS: #{response.inspect}"
    #table.batch_delete([member_id, datetime])
  end
end