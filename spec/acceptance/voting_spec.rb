require 'rails_helper'
require 'capybara/rails'
require 'capybara/email/rspec'
require 'sidekiq/testing'
require 'support/pages/movie_list'
require 'support/pages/movie_new'
require 'support/with_user'

RSpec.describe 'vote on movies', type: :feature do

  let(:page) { Pages::MovieList.new }

  let(:author) {
    User.create(
      uid:   'null|12345',
      name:  'Bob',
      email: 'bob@example.com'
    )
  }

  before do
    Movie.create(
      title:        'Empire strikes back',
      description:  'Who\'s scruffy-looking?',
      date:         '1980-05-21',
      user:         author
    )
  end

  around do |example|
    Sidekiq::Testing.inline! do
      example.run
    end
  end

  context 'when logged out' do
    it 'cannot vote' do
      page.open
      expect {
        page.like('Empire strikes back')
      }.to raise_error(Capybara::ElementNotFound)
    end
  end

  context 'when logged in' do
    with_logged_in_user

    before { page.open }

    it 'can like' do
      page.like('Empire strikes back')
      expect(page).to have_vote_message
    end

    it 'liking a movie notifies the creator' do
      page.like('Empire strikes back')
      open_email(author.email)
      expect(current_email.subject).to match(/Hurrah, your movie was liked/)
    end

    it 'can hate' do
      page.hate('Empire strikes back')
      expect(page).to have_vote_message
    end

    it 'hating a movie notifies the creator' do
      page.hate('Empire strikes back')
      open_email(author.email)
      expect(current_email.subject).to match(/Oopsies, your movie was hated/)
    end

    it 'can unlike' do
      page.like('Empire strikes back')
      page.unlike('Empire strikes back')
      expect(page).to have_unvote_message
    end

    it 'can unhate' do
      page.hate('Empire strikes back')
      page.unhate('Empire strikes back')
      expect(page).to have_unvote_message
    end

    it 'cannot like twice' do
      expect {
        2.times { page.like('Empire strikes back') }
      }.to raise_error(Capybara::ElementNotFound)
    end

    it 'cannot like own movies' do
      Pages::MovieNew.new.open.submit(
        title:       'The Party',
        date:        '1969-08-13',
        description: 'Birdy nom nom')
      page.open
      expect {
        page.like('The Party')
      }.to raise_error(Capybara::ElementNotFound)
    end
  end

end



