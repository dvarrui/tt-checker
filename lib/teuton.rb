require_relative "teuton/application"

module Teuton
  def self.create(path_to_new_dir)
    require_relative "teuton/skeleton"
    Skeleton.create(path_to_new_dir)
  end

  def self.run(projectpath, options = {})
    Application.instance.add_input_params(projectpath, options)
    require_dsl_and_script("teuton/case_manager/dsl") # Define DSL keywords
  end

  def self.readme(projectpath, options = {})
    # Create Readme file for a teuton test
    Application.instance.add_input_params(projectpath, options)
    require_dsl_and_script("teuton/readme/readme") # Define DSL keywords

    app = Application.instance
    readme = Readme.new(app.script_path, app.config_path)
    readme.show
  end

  def self.check(projectpath, options = {})
    Application.instance.add_input_params(projectpath, options)
    require_dsl_and_script("teuton/check/laboratory") # Define DSL keywords

    app = Application.instance
    lab = Laboratory.new(app.script_path, app.config_path)
    if options[:panelconfig]
      lab.show_panelconfig
    else
      lab.show
    end
    puts Rainbow("Check OK!").green
    exit 0
  end

  private_class_method def self.require_dsl_and_script(dslpath)
    app = Application.instance
    require_relative dslpath
    begin
      require_relative app.script_path
    rescue
      warn e.to_s
      warn Rainbow.new("[FAIL ] Reading file #{app.script_path}").red
      warn Rainbow.new("[ERROR] Syntax Error!").red
      exit 1
    end
  end
end
