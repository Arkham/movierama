require 'rails_helper'

RSpec.describe VotesController, :type => :controller do
  let(:user) {
    User.create(
      uid:   'null|12344',
      name:  'Alice',
      email: 'alice@example.com'
    )
  }

  let(:author) {
    User.create(
      uid:   'null|12345',
      name:  'Bob',
      email: 'bob@example.com'
    )
  }

  let (:movie) {
    Movie.create(
      title:        'Empire strikes back',
      description:  'Who\'s scruffy-looking?',
      date:         '1980-05-21',
      user:         author
    )
  }

  before do
    allow(controller).to receive(:authorize!).and_return(nil)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "GET create" do
    it "returns http success" do
      get :create, movie_id: movie.id, t: 'like'
      expect(response).to redirect_to(root_path)
    end

    it "delegates to VotingBooth" do
      booth = double(:booth)
      allow(VotingBooth).to receive(:new).with(user, movie).and_return(booth)
      expect(booth).to receive(:vote).with(:like)

      get :create, movie_id: movie.id, t: 'like'
    end

    it "notifies the event" do
      delayed_mailer = double(:delayed_mailer)

      allow(MovieEventsNotifier).to receive(:delay).and_return(delayed_mailer)
      expect(delayed_mailer).to receive(:movie_voted).with(movie, user, :like)

      get :create, movie_id: movie.id, t: 'like'
    end
  end

  describe "GET destroy" do
    xit "returns http success" do
      get :destroy
      expect(response).to have_http_status(:success)
    end
  end
end
