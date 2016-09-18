module AresMUSH
  module Ranks
    def self.can_manage_ranks?(actor)
      actor.has_any_role?(Global.read_config("ranks", "roles", "can_manage_ranks"))
    end

    def self.rank_group
      Global.read_config("ranks", "rank_group")
    end
    
    def self.group_rank_config(group)
      Global.read_config("ranks", "ranks", group)
    end
    
    def self.all_ranks_for_group(group)
      config = Ranks.group_rank_config(group)
      return nil if config.nil?
      config.values.collect { |t| t.keys }.flatten
    end
    
    def self.allowed_ranks_for_group(group)
      config = Ranks.group_rank_config(group)
      return nil if config.nil?
      ranks = []
      config.values.each do |t|
        ranks << t.select { |t, v| v }
      end
      ranks.collect { |r| r.keys }.flatten
    end
    
    def self.check_rank(char, rank, allow_all)
      return nil if rank.nil?
      
      group = Groups::Interface.group(char, Ranks.rank_group)
      
      if (group.nil?)
        return t('ranks.rank_group_not_set', :group => Ranks.rank_group)
      end
      
      if (allow_all)
        ranks = Ranks.all_ranks_for_group(group)
      else
        ranks = Ranks.allowed_ranks_for_group(group)
      end
      
      if (ranks.nil?)
        return t('ranks.no_ranks_for_group', :group => group)
      end
      
      found = ranks.find { |r| r.downcase == rank.downcase }
      if (found.nil?)
        return t('ranks.invalid_rank_for_group', :group => group)
      end
      
      return nil
    end
    
    def self.app_review(char)
      message = t('ranks.app_review')
      
      if (char.rank.nil?)
        status = t('chargen.are_you_sure', :missing => t('ranks.review_rank_missing'))
      elsif Ranks.check_rank(char, char.rank, false)
        status = t('ranks.review_rank_invalid')
      else
        status = t('chargen.ok')
      end
      
      Chargen::Interface.format_review_status(message, status)
    end
    
  end
end