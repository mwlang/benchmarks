Blog.controllers :post do
  get :index, :map => "/" do 
    @title = "Padrino Benchmark"
    @posts = Post.all
    render 'post/index'
  end

  get :show, :map => "/show/:id" do 
  end
  
  get :edit, :map => "/edit/:id" do 
  end
  
  get :destroy, :map => "/destroy/:id" do 
  end
  
end