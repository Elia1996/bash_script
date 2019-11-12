from selenium import webdriver
import time
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.common.keys import Keys

class web_surf:
	def __init__(sf,private_window=False):
		sf.private_window=private_window
		if private_window:
			o=Options()
			o.add_argument('-private')
			sf.driver=webdriver.Firefox(firefox_options=o)
		else:
			sf.driver=webdriver.Firefox()
		sf.driver.implicitly_wait(30)
		sf.driver.maximize_window()
	
	def open_site(sf, namesite):
		# Navigate to the application home page
		sf.driver.get(namesite)

	def login(sf, Id_user, Id_passw,  user, passw):
		# get the search textbox
		sf.search_field = sf.driver.find_element_by_id(Id_user)
		sf.search_field.clear()
		# enter search keyword and submit
		sf.search_field.send_keys(user)
		sf.search_field.send_keys(Keys.ENTER)
		#sf.driver.sendKeys(Keys.RETURN);
		time.sleep(1)
		# password
		sf.search_field = sf.driver.find_element_by_name(Id_passw)
		sf.search_field.send_keys(passw)
		#sf.driver.sendKeys(Keys.RETURN);
		sf.search_field.send_keys(Keys.ENTER)




#dri=web_surf(True)
#dri.open_site("https://accounts.google.com/signin/v2/identifier?service=mail&passive=true&rm=false&continue=https%3A%2F%2Fmail.google.com%2Fmail%2F&ss=1&scc=1&ltmpl=default&ltmplcache=2&emr=1&osid=1&flowName=GlifWebSignIn&flowEntry=ServiceLogin")
#dri.login("identifierId","password", "ribaldoneelia@gmail.com","scarranotipo19")
