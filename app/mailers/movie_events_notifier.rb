class MovieEventsNotifier < ActionMailer::Base
  default from: "from@example.com"

  def movie_voted(movie, user, type)
    if type == :like
      subject = "Hurrah, your movie was liked"
    elsif type == :hate
      subject = "Oopsies, your movie was hated"
    else
      raise "Invalid type passed: #{type}"
    end

    @message = <<~EOM
      Hello #{movie.user.name}, #{user.name} #{type}d your movie #{movie.title}
    EOM

    mail(to: movie.user.email, subject: subject)
  end
end
