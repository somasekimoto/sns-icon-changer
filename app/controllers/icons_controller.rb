class IconsController < ApplicationController
  before_action :set_s3_credentials, only: [:fetch, :post]
  before_action :twitter, only: [:post]

  def fetch
    @icons = {}
    @s3_bucket.objects().each{|object|
      if is_image?(object)
        @icons[object.data().key.split("/")[0]] = object.presigned_url(:get)
      end
    }
    render action: :index
  end

  def post
    @s3_bucket.objects().each{|object|
      if is_image?(object)
        @s3_bucket.put_object(key: object.data().key, body: File.open(params[:icon]))
      end
    }
    obj = @s3_bucket.object('twitter/23laugh.jpeg')
    file = obj.presigned_url(:get, expires_in: 60)
    @twitter_client.update_profile_image(URI.open(file))
  end

  def is_image?(object)
    return object.data().key.match(/.+\.jpeg|\.jpg|\.png|\.gif/)
  end

private
  def set_s3_credentials
    @region = ENV['S3_REGION']
    @bucket = ENV['S3_BUCKET']
    @access_key_id=ENV['S3_ACCESS_KEY_ID']
    @secret_access_key=ENV['S3_SECRET_ACCESS_KEY']
    @s3_bucket = Aws::S3::Resource.new(
      region: @region,
      access_key_id: @access_key_id,
      secret_access_key: @secret_access_key,
    ).bucket(@bucket)
  end
  def twitter
    @twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key=ENV['TWITTER_API_KEY']
      config.consumer_secret=ENV['TWITTER_API_SECRET']
      config.access_token=ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret=ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end
  end
end
