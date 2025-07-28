class AnalyticsController < ApplicationController
  def index
    prune_partials
    @stats = aggregate_stats
  end

  def trends
    prune_partials
    render json: aggregate_stats
  end

  private

  def aggregate_stats
    term_counts = Search
                    .group(:query)
                    .order(Arel.sql('COUNT(*) DESC'))
                    .limit(50)
                    .count

    total = term_counts.values.sum.to_f

    term_counts.each_with_object({}) do |(term, cnt), out|
      out[term] = {
        total: cnt,
        pct:   (total.zero? ? 0 : (cnt / total * 100).round(1))
      }
    end
  end

  def prune_partials
    cutoff = 1.hour.ago
    ips    = Search.where('last_seen_at > ?', cutoff)
                    .pluck(:user_ip)
                    .uniq

    ips.each do |ip|
      recs = Search.where(user_ip: ip)
      next if recs.size < 2

      latest    = recs.order(last_seen_at: :desc).first
      leftovers = recs.where.not(id: latest.id).select do |r|
        latest.query.start_with?(r.query) && latest.query != r.query
      end

      Search.delete(leftovers.map(&:id)) if leftovers.any?
    end
  end
end
