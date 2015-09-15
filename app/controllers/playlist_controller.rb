class PlaylistController < ApplicationController
  def index
    response.headers["X-FRAME-OPTIONS"] = "ALLOW-FROM http://wcbn.org"
    iframe = params[:from] == 'iframe'

    songs = Song.includes(:episode).where(at: 6.hours.ago..Time.zone.now)
    past_episodes = Episode.includes(:dj, :songs, show: [:dj], trainee: [:episodes])
      .where(ending: 6.hours.ago..Time.zone.now)
    future_episodes = Episode.includes(:dj, :songs, show: [:dj], trainee: [:episodes])
      .where(beginning: Time.zone.now..4.hours.since)
    @on_air = Episode.on_air
    episodes = past_episodes + future_episodes
    episodes -= [@on_air]
    signoff_instances = SignoffInstance.where(at: 6.hours.ago..4.hours.since)

    items = songs + episodes
    if iframe
      def @on_air.at
        Time.zone.now
      end
      items += [@on_air]
    end
    items += signoff_instances if playlist_editor_signed_in?

    items.sort_by!(&:at).reverse!
    @past_items = items.select{|i| i.at <= Time.zone.now }
    @future_items = items - @past_items

    session[:confirm_episode] = false unless session[:song]
    @song = Song.new(session.delete(:song))
    @song ||= Song.new
    @song.episode ||= @on_air

    fresh_when last_modified: Song.last.updated_at, public: true

    if iframe
      render 'iframe', layout: 'iframe' and return
    end
  end
end
