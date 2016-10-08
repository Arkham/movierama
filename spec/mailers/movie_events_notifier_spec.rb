require 'rails_helper'

RSpec.describe MovieEventsNotifier, type: :mailer do
  describe "movie_voted" do
    let(:user) {
      double(:user, name: "Alice", email: "alice@example.com")
    }

    let(:author) {
      double(:user, name: "Bob", email: "bob@example.com")
    }

    let(:movie) {
      double(:movie, user: author, title: "Citizen Kane")
    }

    it "assigns the movie owner as recipient" do
      mailer = described_class.movie_voted(movie, user, :like)

      expect(mailer.to).to eq([author.email])
    end

    it "assigns a nice subject when movie is liked" do
      mailer = described_class.movie_voted(movie, user, :like)

      expect(mailer.subject).to match(/Hurrah, your movie was liked/)
    end

    it "assigns a nice message when movie is liked" do
      mailer = described_class.movie_voted(movie, user, :like)

      expect(mailer.body).to match(/Hello Bob, Alice liked your movie Citizen Kane/)
    end

    it "assigns a sorry subject when movie is hated" do
      mailer = described_class.movie_voted(movie, user, :hate)

      expect(mailer.subject).to match(/Oopsies, your movie was hated/)
    end

    it "assigns a sorry message when movie is hated" do
      mailer = described_class.movie_voted(movie, user, :hate)

      expect(mailer.body).to match(/Hello Bob, Alice hated your movie Citizen Kane/)
    end

    it "raises an exception when type is invalid" do
      expect { described_class.movie_voted(movie, user, :hello) }.to raise_error
    end
  end
end
