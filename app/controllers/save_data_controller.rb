class SaveDataController < ApplicationController
  def index
    @info = Aws.get_records_from_db
    puts "info is: #{@info.inspect}"
  end

  def save
    name  = params['name']
    mob   = params['mob']
    email = params['email']
    mess  = params['mess']
    aws_params = Hash.new
    aws_params[:mob] = mob
    aws_params[:custom_fields]    = {
        'name'    => name,
        'email'   => email,
        'message' => mess,
    }
    if Aws.save_records_to_db(aws_params)
      flash[:notice] = "Message Sent!"
    else
      flash[:error] = "Error While Save to DynamoDB!"
    end
    redirect_to save_data_index_path
  end

  def delete
    datetime = params['datetime']
    member_id = params['member_id'].to_i
    puts "params datetime is #{params['datetime']}"
    puts "params member_id is #{params['member_id']}"
    Aws.delete_item(datetime, member_id)
    redirect_to save_data_index_path
  end

  def update

  end

  def show
    dt = params[:datetime]
  end

end
