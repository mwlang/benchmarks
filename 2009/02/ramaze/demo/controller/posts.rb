class PostsController < Controller

  def index
    @title = "What's in a Title, anyhow?"
    @posts = Post.find(:all)
  end

end
