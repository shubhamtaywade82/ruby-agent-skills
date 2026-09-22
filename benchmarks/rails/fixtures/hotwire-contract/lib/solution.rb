# frozen_string_literal: true
class HotwireContract
  def initialize(user:,authorized_ids:) = (@user,@authorized_ids=user,authorized_ids)
  def frame_response(id:,content:) = return({status:403}) unless @authorized_ids.include?(id); {status:200,frame_id:"item_#{id}",body:content}
  def stream_response(id:,action:,content:) = return({status:403}) unless @authorized_ids.include?(id); {action:,target:"item_#{id}",body:content}
  def csrf_valid?(token,expected) = token==expected && !token.nil?
  def cache_key(id:) = "tenant:#{@user[:tenant_id]}:item:#{id}"
  def controller_connect = :connected
  def controller_disconnect = :disconnected
end
