property :directory, String, default: ''

action :apply do
  bash 'Create template' do
    user 'root'
    environment({
      'directory' => new_resource.directory,
    })
    code <<-EOH
    cat <<EOT >> /tmp/patch-allow-override
    <Directory $directory>
      AllowOverride All
    </Directory>
  EOH
  end

  bash 'Apply patch' do
    user 'root'
    environment({
      'apacheConfig' => '/etc/apache2/apache2.conf',
    })
    code <<-EOH
line_number="$(cat -n $apacheConfig | grep "/var/www/" | awk '{ print $1 }')"
((line_number=line_number+5))
sed -i "${line_number}r /tmp/patch-allow-override" "$apacheConfig"
EOH
  end
end
