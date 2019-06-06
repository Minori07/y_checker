class ListsController < ApplicationController
  before_action :authenticate_user!
  def index
  	@lists = current_user.lists
  	@spaces = current_user.spaces
  	@body = "なし"
  	last_n = @lists[@lists.length-1].name
  	last_a = @lists[@lists.length-(@spaces.length+1)].c_at
  	last_s = @lists[@lists.length-1].switch
  	last_r = @lists[@lists.length-1].room

  	require 'net/imap'
	require 'kconv'
	require 'mail'

	# imapに接続
	imap_host = 'imap.gmail.com' # imapをgmailのhostに設定する
	imap_usessl = true # imapのsslを有効にする
	imap_port = 993 # ssl有効なら993、そうでなければ143
	imap = Net::IMAP.new(imap_host, imap_port, imap_usessl)
	# imapにログイン
	imap_user = 'minotaka.0730@gmail.com'
	imap_passwd = '0730Minori'
	imap.login(imap_user, imap_passwd)

	imap.select('INBOX') # 対象のメールボックスを選択
	ids = imap.search(['ALL']) # 全てのメールを取得

	imap.fetch(ids, "RFC822").each do |mail|
	  m = Mail.new(mail.attr["RFC822"])
	  # multipartなメールかチェック
	  if m.multipart?
	    # plantextなメールかチェック
	    if m.text_part
	      @body = m.text_part.decoded.to_s
	    # htmlなメールかチェック
	    elsif m.html_par
	      body = m.html_part.decoded
	    end
	  else
	    body = m.body
	  end
	end

	@b = @body.split(",")
	    if @b[0] == "test" 
	    	if last_s ==  1 && @b[1] != last_n && @b[3] != last_r
				list = List.new
				list = current_user.lists.new
				list.name = @b[1]
				list.switch = 1
				list.c_at = Time.parse(@b[2])
				list.c_day = Date.parse(@b[2])
				list.room = @b[3].to_i
				list.save!
			elsif last_s == 0 && Time.parse(@b[2]) != last_a
				list = List.new
				list = current_user.lists.new
				list.name = @b[1]
				list.switch = 1
				list.c_at = Time.parse(@b[2])
				list.c_day = Date.parse(@b[2])
				list.room = @b[3].to_i
				list.save!
			end
		end

	

  end

  def room
  	@spaces = target_space params[:room]
  	@lists = target_room params[:room]
  end

  def reset
  	spaces = current_user.spaces
  	i = 0
  	s = 0
  	for n in 0..4 do
  		m = 0
	  	while spaces[i].room == n && i < spaces.length-1
		  	list = List.new
			list = current_user.lists.new
			list.name = "0#{m}"
			list.switch = 0
			list.c_at = Time.now
			list.c_day = Time.now
			list.room = n
			list.save!
			m += 1
			i += 1
		end
		s = m
	end
	list = List.new
	list = current_user.lists.new
	list.name = "0#{s}"
	list.switch = 0
	list.c_at = Time.now
	list.c_day = Time.now
	list.room = 4
	list.save!
	redirect_to lists_url
  end

  def show
  	@list = target_list params[:id]
  end

  def carender
  	@time = params[:time]
  	@days = []
  	@t = Time.now
  end

  def month
  	@time = params[:time]
  	@days = []
  	@t = DateTime.parse(params[:date])
  end

  def destroy
    @list = target_list params[:id]
    @list.destroy
    redirect_to lists_url
  end

  private
    def target_list list_id
      current_user.lists.where(id: list_id).take
    end

    def target_room list_room
      current_user.lists.where(room: list_room)
    end

    def target_space space_room
      current_user.spaces.where(room: space_room)
    end

    def list_params
      params.require(:list).permit(:name, :switch, :c_at, :s_day, :room)
    end

end
