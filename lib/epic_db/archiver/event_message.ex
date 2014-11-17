defmodule EpicDb.Archiver.EventMessage do
  use AMQP

  defstruct channel: nil, tag: nil, redelivered: nil, data: nil 

  def ack(message = %EpicDb.Archiver.EventMessage{}) do
    Basic.ack message.channel, message.tag
  end

  def nack(message = %EpicDb.Archiver.EventMessage{}, options \\ []) do
    Basic.nack message.channel, message.tag, options
  end

  def reject(message = %EpicDb.Archiver.EventMessage{}, options \\ []) do
    Basic.reject message.channel, message.tag, options
  end

  def requeue_once(message) do
    reject message, requeue: !message.redelivered
  end

  def target_for(message = %EpicDb.Archiver.EventMessage{}) do
    :jsx.decode(message.data)
    |> find_target
  end

  ## Private Functions

  defp find_target([{"eventTarget", target}|_]) do
    target
  end
  defp find_target([_head|tail]) do
    find_target(tail)
  end
end
