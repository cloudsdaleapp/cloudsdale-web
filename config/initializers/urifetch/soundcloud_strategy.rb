# encoding: utf-8

Urifetch.register do 
	match /(soundcloud.com)\/([a-z]+)\/([a-z0-9\-]+)\/?/i, :soundcloud_track
end

Urifetch::Strategy.layout(:soundcloud_track) do

	before_request do
		@skip_request = true

		track = Cloudsdale.soundcloud.get('/resolve', :url => match_data[0])
		if track
			data.title					= track.title
			data.author 				= track.user.username
			data.preview_image 	= track.artwork_url
			data.description		= track.description
			data.genre					= track.genre

			# Sets status
			status = ["200","OK"]
		end
	end

	after_success do |request|
	end

	after_failure do |error|
	end
end

Urifetch::Strategy.layout(:soundcloud_user) do

	before_request do
		# Skips the normal request
		@skip_request = true

		user = Cloudsdale.soundcloud.get('/resolve', :url => match_data[0])
		if user
			data.username				= user.username
			data.avatar_url			= user.avatar_url
			data.full_name			= user.full_name
			data.country				=	user.country

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