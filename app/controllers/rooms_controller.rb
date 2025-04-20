class RoomsController < ApplicationController
  def index
    @rooms = Room.active
  end
end
