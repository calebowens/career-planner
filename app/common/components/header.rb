class Components::Header < ApplicationView
  def template
    header do
      logo_path =
        if Current.user
          dashboard_home_path
        else
          root_path
        end

      link_to "Career Composer", logo_path, class: "h2 mb-0"

      nav do
        with_options class: "mb-0" do |styled|
          if Current.user
            styled.link_to "My Profile", profile_setup_path
            styled.link_to "Dashboard", dashboard_home_path
            styled.link_to "Log out", authentication_logout_path, data: {turbo_method: :delete}
          else
            styled.link_to "Login", authentication_login_path
            styled.link_to "Register", authentication_register_path
          end
        end
      end
    end
  end
end
