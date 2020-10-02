# Copy this file to dbag-secrets.rb and use chef-run to deploy data bag secrets
# to nodes.
file '/opt/chef/global_secret_test' do
  content 'secret-content-goes-here'
  mode '0600'
  owner 'root'
end
file '/opt/chef/ymir_secret_test' do
  content 'secret-content-goes-here'
  mode '0600'
  owner 'root'
end