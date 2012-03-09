require  "/Users/seb/Developer/Ruby/capistrano-db-tasks/lib/capistrano-db-tasks/dbtasks"
# # Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

# # prevent loading when called by Bundler, only load when called by capistrano
# if caller.any? { |callstack_line| callstack_line =~ /^Capfile:/ }
#   unless Capistrano::Configuration.respond_to?(:instance)
#     abort "capistrano-deployment-tasks requires Capistrano 2"
#   end

#   Capistrano::Configuration.instance(:must_exist).load do
#     [ :default, :setup, :update, :update_code, :finalize_update, :symlink, :stop, :start, :restart, :migrate, :migrations, :cleanup, :check, :cold, :"web:disable", :"web:enable" ].each do |step|
#       step_sanitized_name = step.to_s.gsub(/:/, '_')
#       [ :before, :after ].each do |timing|
#         if File.executable?(File.expand_path("script/deploy_#{timing}_#{step_sanitized_name}"))
#           namespace :deploy do
#             namespace timing do
#               task step_sanitized_name do
#                 run "cd #{current_path} ; script/deploy_#{timing}_#{step_sanitized_name} #{shared_path}"
#               end
#             end
#           end

#           call(timing, "deploy:#{step}", "deploy:#{timing}:#{step_sanitized_name}") 
#         end
#       end
#     end
#   end
# end
