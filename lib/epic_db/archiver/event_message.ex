defmodule EpicDb.Archiver.EventMessage do
  use AMQP
  require Logger

  defstruct channel:     nil,
            tag:         nil,
            redelivered: nil,
            data:        nil,
            target:      nil,
            timestamp:   nil,
            index:       nil

  @timestamp_regex ~r/
    ^(?<year>-?(?:[1-9][0-9]*)?[0-9]{4})-                 # Year
    (?<month>1[0-2]|0[1-9])-                              # Month
    (?<day>3[0-1]|0[1-9]|[1-2][0-9])                      # Day
    T(?<hour>2[0-3]|[0-1][0-9]):                          # Hours
    (?<minute>[0-5][0-9]):                                # Minutes
    (?<second>[0-5][0-9])                                 # Seconds
    (?<ms>\.[0-9]+)?                                      # Milliseconds
    (?<timezone>Z|[+-](?:2[0-3]|[0-1][0-9]):[0-5][0-9])?$ # Timezone
  /x

  def new(channel, tag, redelivered, data) do
    ExStatsD.increment("epic_db.events.message_recieved")
    %{"eventTarget" => target, "eventTimestamp" => timestamp} = :jsxn.decode(data)
    %EpicDb.Archiver.EventMessage{
      channel:     channel,
      tag:         tag,
      redelivered: redelivered,
      data:        data,
      target:      target,
      timestamp:   timestamp,
      index:       index_for(timestamp)}
  end

  def ack(message = %EpicDb.Archiver.EventMessage{}) do
    ExStatsD.increment("epic_db.events.message_acked")
    Basic.ack message.channel, message.tag
  end

  def nack(message = %EpicDb.Archiver.EventMessage{}, options \\ []) do
    ExStatsD.increment("epic_db.events.message_nacked")
    Basic.nack message.channel, message.tag, options
  end

  def reject(message = %EpicDb.Archiver.EventMessage{}, options \\ []) do
    ExStatsD.increment("epic_db.events.message_rejected")
    Basic.reject message.channel, message.tag, options
  end

  def requeue_once(message) do
    reject message, requeue: !message.redelivered
  end

  def url_for(message = %EpicDb.Archiver.EventMessage{}, [host|_other_hosts]) do
    "#{host}/#{message.index}/#{message.target}"
  end

  ## Private Functions

  #TODO: Adjust day for timezone
  defp index_for(timestamp) do
    %{"year" => year, "month" => month, "day" => day} = Regex.named_captures(@timestamp_regex, timestamp)
    "events-#{year}-#{month}-#{day}"
  end
end
