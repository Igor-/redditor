# coding: utf-8

class Admin::Redditor::PagesController < Admin::ApplicationController
  layout false

  def sort
    params[:sort].each do |k, v|
      v.each do |klass, info|
        klass.camelcase.constantize.find_by_id(info[:index]).update_attributes(position: info[:position]) rescue nil
      end
    end

    render :nothing => true
  end  
end