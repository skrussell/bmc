require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'ipmi', 'ipmitool.rb'))

Puppet::Type.type(:bmc_ldap).provide(:racadm7) do

  desc "Manage LDAP configuration via racadm7."

  confine :manufactor_id => :'674'
  confine :osfamily => [:redhat, :debian]
  confine :exists => '/opt/dell/srvadmin/bin/idracadm'

  commands :ipmitool => 'ipmitool'

  mk_resource_methods

  def create
    @property_hash[:ensure] = :present
    self.server= resource[:server]
    self.base_dn= resource[:base_dn]
    self.server_port= resource[:server_port] unless resource[:server_port].nil?
    self.group_attribute_is_dn= resource[:group_attribute_is_dn] unless resource[:group_attribute_is_dn].nil?
    self.bind_dn= resource[:bind_dn] unless resource[:bind_dn].nil?
    self.user_attribute= resource[:user_attribute] unless resource[:user_attribute].nil?
    self.group_attribue= resource[:group_attribue] unless resource[:group_attribue].nil?
    self.certificate_validate = resource[:certificate_validate] unless resource[:certificate_validate].nil?
    self.password= resource[:bind_password] unless resource[:bind_password].nil?
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.LDAP.Enable', 'Enabled'])
  end

  def destroy
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.LDAP.Enable', 'Disabled'])
    self.server= "''"
    self.group_attribute_is_dn= :true
    self.server_port= 636
    self.bind_dn= "''"
    self.password= "''"
    self.base_dn = "''"
    self.user_attribute= "''"
    self.group_attribue= "''"
    self.certificate_validate = :true
    @property_hash[:ensure] = :absent
  end

  def exists?
    unless @property_hash.key? :ensure
      racadm_out = Racadm::Racadm.racadm_call(resource, ['get', 'iDRAC.LDAP'])
      iDRAC_LDAP = Racadm::Racadm.parse_racadm racadm_out
      @property_hash[:server] = iDRAC_LDAP['Server']
      @property_hash[:server_port] = iDRAC_LDAP['Port']
      @property_hash[:bind_dn] = iDRAC_LDAP['BindDN']
      @property_hash[:base_dn] = iDRAC_LDAP['BaseDN']
      @property_hash[:user_attribute] = iDRAC_LDAP['UserAttribute']
      @property_hash[:group_attribue] = iDRAC_LDAP['GroupAttribute']
      @property_hash[:search_filer] = iDRAC_LDAP['SearchFilter']
      @property_hash[:certificate_validate] = (iDRAC_LDAP['CertValidationEnable'].eql? 'Enabled').to_s
      @property_hash[:group_attribute_is_dn] = (iDRAC_LDAP['GroupAttributeIsDN'].eql? 'Enabled').to_s
      @property_hash[:ensure] = (iDRAC_LDAP['Enable'].eql? 'Enabled') ? :present : :absent
      #Have not been able to find a way to test if the password is changed so to make sure
      #it's set every time (if enabled)
      if @property_hash[:ensure] == :present && !resource[:bind_password].nil?
        self.password= resource[:bind_password]
      end
    end
    @property_hash[:ensure] == :present
  end

  def server= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.LDAP.Server', value])
  end

  def server_port= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.LDAP.Port', value])
  end

  def bind_dn= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.LDAP.BindDN', value])
  end

  def base_dn= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.LDAP.BaseDN', value])
  end

  def user_attribute= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.LDAP.UserAttribute', value])
  end

  def group_attribue= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.LDAP.GroupAttribute', value])
  end

  def search_filer= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.LDAP.SearchFilter', value])
  end

  def certificate_validate= value
    Racadm::Racadm.racadm_call(
        resource, ['set', 'iDRAC.LDAP.CertValidationEnable', value == :true ? "Enabled" : "Disabled"])
  end

  def group_attribute_is_dn= value
    Racadm::Racadm.racadm_call(
        resource, ['set', 'iDRAC.LDAP.GroupAttributeIsDN', value == :true ? "Enabled" : "Disabled"])
  end

  def password= value
    Racadm::Racadm.racadm_call(resource, ['set', 'iDRAC.LDAP.BindPassword', value])
  end
end