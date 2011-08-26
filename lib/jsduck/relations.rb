module JsDuck

  # Provides information about relations between classes.
  #
  # Also provides a place to look up classes by name.
  #
  # The constructor is initialized with array of all available classes
  # and list of class names to ignore.  By default the latter list
  # contains only JavaScript base class "Object".
  class Relations
    # Returns list of all classes
    attr_reader :classes

    def initialize(classes = [], ignorables = [])
      @classes = classes
      @ignorables = {}
      ignorables.each {|classname| @ignorables[classname] = true }

      # First build class lookup table; building lookup tables for
      # mixins and subclasses will depend on that.
      @lookup = {}
      @classes.each do |cls|
        @lookup[cls.full_name] = cls
        (cls[:alternateClassNames] || []).each do |alt_name|
          @lookup[alt_name] = cls
        end
        cls.relations = self
      end

      @subs = {}
      @mixes = {}
      @classes.each do |cls|
        reg_subclasses(cls)
        reg_mixed_into(cls)
      end
    end

    # Looks up class by name, nil if not found
    def [](classname)
      @lookup[classname]
    end

    # Returns true if class is in list of ignored classes.
    def ignore?(classname)
      @ignorables[classname]
    end

    def each(&block)
      @classes.each(&block)
    end

    def reg_subclasses(cls)
      if !cls.parent
        # do nothing
      elsif @subs[cls.parent.full_name]
        @subs[cls.parent.full_name] << cls
      else
        @subs[cls.parent.full_name] = [cls]
      end
    end

    # Returns subclasses of particular class, empty array if none
    def subclasses(cls)
      @subs[cls.full_name] || []
    end

    def reg_mixed_into(cls)
      cls.mixins.each do |mix|
        if @mixes[mix.full_name]
          @mixes[mix.full_name] << cls
        else
          @mixes[mix.full_name] = [cls]
        end
      end
    end

    # Returns classes having particular mixin, empty array if none
    def mixed_into(cls)
      @mixes[cls.full_name] || []
    end
  end

end
