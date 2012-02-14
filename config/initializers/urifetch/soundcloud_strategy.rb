# encoding: utf-8

Urifetch.register do 
	match /(soundcloud.com)\/([a-z0-9]+)\/?([a-z0-9\-]+)?\/?$/i, :soundcloud_track do
		match /(soundcloud.com)\/([a-z0-9]+)\/([a-z0-9\-]+)\/?$/i, :soundcloud_track
		match /(soundcloud.com)\/([a-z0-9]+)\/?$/i, :soundcloud_user
	end
end

Urifetch::Strategy.layout(:soundcloud_track) do

	before_request do
		@skip_request = true
    @uri = Addressable::URI.heuristic_parse(match_data.string)
    
		begin
		  track = Cloudsdale.soundcloud.get('/resolve', :url => @uri.to_s)
		rescue Soundcloud::ResponseError => e
		  track = nil
		  status = ["404","Not Found"]
		end
		
		if track
		  data.match_id       = @uri.to_s
			data.title					= track.title
			data.author 				= track.user.username
			data.preview_image 	= track.artwork_url
			data.description		= track.description
			data.genre					= track.genre

			# Sets status
			status = ["200","OK"]
		end
	end

end

Urifetch::Strategy.layout(:soundcloud_user) do

	before_request do
		@skip_request = true
		@uri = Addressable::URI.heuristic_parse(match_data.string)

		begin
			user = Cloudsdale.soundcloud.get('/resolve', :url => @uri.to_s)
		rescue Soundcloud::ResponseError => e
			user = nil
			status = ["404", "Not Found"]
		end

		if user
			data.match_id				= @uri.to_s
			data.title					= user.username
			data.preview_image	= user.avatar_url
			data.full_name			= user.full_name
			data.country				=	user.country
			data.description		=	user.description

			# Sets status
			status = ["200","OK"]
		end
	end

	after_success do |request|
	end

	after_failure do |error|
	end
end

Urifetch::Strategy.layout(:soundcloud_playlist) do

	before_request do
		# Skips the normal request
		@skip_request = true

		playlist = Cloudsdale.soundcloud.get('/resolve', :url => match_data[0])
		if playlist
			data.title					= playlist.title
			data.artwork_url		= playlist.artwork_url
			data.owner_name			= playlist.user.username
			data.description		= playlist.description

			# Sets status
			status = ["200","OK"]
		end
	end

	after_success do |request|
	end

	after_failure do |error|
	end
end

Urifetch::Strategy.layout(:soundcloud_group) do

	before_request do
		# Skips the normal request
		@skip_request = true

		group = Cloudsdale.soundcloud.get('/resolve', :url => match_data[0])
		if group
			data.name 					= group.name
			data.artwork_url		= group.artwork_url
			data.description		=	group.description

			# Sets status
			status = ["200","OK"]
		end
	end

	after_success do |request|
	end

	after_failure do |error|
	end
end