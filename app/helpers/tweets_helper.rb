module TweetsHelper
  def format_user_name(tweet_content)
    tweet_content.gsub(/(@(\w+))/, %Q{<a href="http://twitter.com/\\2" target="_blank">\\1</a>})
  end
  
  def format_hashtag(tweet_content)
    tweet_content.gsub(/(#(\w+))/, %Q{<a href="https://twitter.com/#!/search?q=%23\\2" target="_blank">\\1</a>})
  end
  
  def format_tweet(tweet)
    content = auto_link(format_user_name(format_hashtag(tweet.content)), :html => { :target => '_blank' })
  end

  def avatar_url(politician)
    politician.profile_image_url
  end

  def byline(tweet, html = true)
    if (Time.now - tweet.modified).to_i > (60 * 60 * 24 * 365)
      tweet_time = tweet.modified.strftime("%l:%H %p")
      tweet_date = tweet.modified.strftime("%d %b %y") # 03 Jun 12
      tweet_when = "at <a class=""linkUnderline"" href=""/tweet/#{tweet.id}"">#{tweet_time} on #{tweet_date}</a>"
    elsif (Time.now - tweet.modified).to_i > (60 * 60 * 24)
      tweet_time = tweet.modified.strftime("%l:%H %p")
      tweet_date = tweet.modified.strftime("%d %b") # 03 Jun
      tweet_when = "at <a class=""linkUnderline"" href=""/tweet/#{tweet.id}"">#{tweet_time} on #{tweet_date}</a>"
    else
      since_tweet = time_ago_in_words tweet.modified
      tweet_when = "<a class=""linkUnderline"" href=""/tweet/#{tweet.id}"">#{since_tweet}</a> ago"
    end
    delete_delay = (tweet.modified - tweet.created).to_i
    
    delay = if delete_delay > (60 * 60 * 24 * 7)
      "after #{pluralize(delete_delay / (60 * 60 * 24 * 7), "week")}"
    elsif delete_delay > (60 * 60 * 24)
      "after #{pluralize(delete_delay / (60 * 60 * 24), "day")}"
    elsif delete_delay > (60 * 60)
      "after #{pluralize(delete_delay / (60 * 60), "hour")}"
    elsif delete_delay > 60
      "after #{pluralize(delete_delay / 60, "minute")}"
    elsif delete_delay > 1
      "after #{pluralize delete_delay, "second"}"
    else
      "immediately"
    end

    if html
      source = tweet.details["source"].to_s.html_safe
      byline = "<a href=\"http://twitter.com/#{tweet.politician.user_name}\" class=\"twitter\">#{tweet.details['user']['name']}</a>".html_safe
      byline += t(:byline,
                  :scope => [:politwoops, :tweets],
                  :when => tweet_when,
                  :what => source,
                  :delay => delay).html_safe
      byline
    else
      t :byline_text, :scope => [:politwoops, :tweets], :when => tweet_when, :delay => delay
    end
  end

  def rss_date(time)
    time.strftime "%a, %d %b %Y %H:%M:%S %z"
  end

end
