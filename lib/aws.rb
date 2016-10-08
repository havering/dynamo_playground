module Aws
  require 'time'
  #a init method to be used for initialisation when the rails application start
  def self.init
    @@dynamo_db = false
    if AWS_SETTINGS["aws_dynamo"]
      @@dynamo_db = Aws::DynamoDB::Client.new(AWS_SETTINGS["aws_dynamo"])
    end
  end

  #the method that save in aws database
  def self.save_records_to_db(params)
    return if !@@dynamo_db

    fields = {
      'member_id' => 1, #primary partition key
      'datetime' => Time.now.utc.iso8601, #primary sort key
    }
    fields.merge!(params[:custom_fields]) if params[:custom_fields]
    puts "fields are #{fields.inspect}"
    # @@dynamo_table.items.create(fields)
    response = @@dynamo_db.put_item({
                                      table_name: "records", # required
                                      item: {# required
                                             'member_id' => 1,
                                             'datetime' => Time.now.utc.iso8601,
                                             'name' => fields['name'],
                                             'message' => fields['message'],
                                             'email' => fields['email']
                                      }})
  end

  def self.get_records_from_db
    all_tables = @@dynamo_db.list_tables
    my_table = all_tables.table_names.first
    response = @@dynamo_db.scan(table_name: my_table)
    items = response.items
    items
  end

  def self.get_table_info
    return if !@@dynamo_db

    @@dynamo_db.list_tables
  end

  def self.delete_item(datetime, member_id)
    all_tables = @@dynamo_db.list_tables
    my_table = all_tables.table_names.first

    params = {
      table_name: my_table,
      key: {
        'member_id' => member_id,
        'datetime' => datetime
      }
    }

    response = @@dynamo_db.delete_item(params)
  end

  def self.list_item(datetime, member_id)
    all_tables = @@dynamo_db.list_tables
    my_table = all_tables.table_names.first

    response = @@dynamo_db.get_item({
                                      table_name: my_table,
                                      key: {
                                        'member_id' => member_id,
                                        'datetime' => datetime
                                      }
                                    })
    response.item
  end

  def self.update_item(mess, name, email, datetime, member_id)
    all_tables = @@dynamo_db.list_tables
    my_table = all_tables.table_names.first

    response = @@dynamo_db.update_item({
                                         table_name: my_table, # required
                                         key: {
                                           'member_id' => member_id,
                                           'datetime' => datetime
                                         },
                                         attribute_updates: {
                                           "message" => {
                                             value: mess,
                                             action: "PUT",
                                           },
                                           "name" => {
                                             value: name,
                                             action: "PUT",
                                           },
                                           "email" => {
                                             value: email, # value <Hash,Array,String,Numeric,Boolean,IO,Set,nil>
                                             action: "PUT", # accepts ADD, PUT, DELETE
                                           }
                                         }})
  end
end