
class MainController < Controller

  def index
    @posts = Post.all
  end

end
