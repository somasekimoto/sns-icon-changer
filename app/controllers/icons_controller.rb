class IconsController < ApplicationController
  before_action :set_s3_credentials, only: [:fetch]
  def fetch()
    s3_bucket = Aws::S3::Resource.new(
      region: @region,
      access_key_id: @access_key_id,
      secret_access_key: @secret_access_key,
    ).bucket(@bucket)
    
    @icons = {}
    s3_bucket.objects().each{|object|
      if object.data().key.match(/.+\.jpeg|\.jpg|\.png|\.gif/)
        @icons[object.data().key.split("/")[0]] = object.presigned_url(:get)
      end
    }
    # render json: {icons: icons}
    render action: :index
  end

  def post()
    puts 'its in'
    puts params[:post]
  end

private
  def set_s3_credentials
    @region = ENV['S3_REGION']
    @bucket = ENV['S3_BUCKET']
    @access_key_id=ENV['S3_ACCESS_KEY_ID']
    @secret_access_key=ENV['S3_SECRET_ACCESS_KEY']
  end
end
