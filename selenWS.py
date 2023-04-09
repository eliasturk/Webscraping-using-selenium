from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select
import pandas as pd
import re

PATH = "C:\Program Files (x86)\chromedriver.exe"
driver = webdriver.Chrome(PATH)
driver.get('https://foreverzoe.com/collections/all-products')

wait = WebDriverWait(driver, 30)
first_element = wait.until(EC.element_to_be_clickable((By.XPATH, "//div[@class='row']//div[@class='ultimate-currency']//div//div//div[@class='Launch__Arrow-sc-17021qg-6 fYjnRT']")))

# click the first element
first_element.click()

# wait for the second element to be clickable
second_element = wait.until(EC.element_to_be_clickable((By.XPATH, "//div[contains(text(),'USD')]")))

# click the second element
second_element.click()

def scroll_down(driver):
    # Scroll down to the bottom of the page
    driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")

sales=[]
discounts=[]
products=[]
discounted_prices=[]
original_prices=[]
sizes=[]
colors=[]

# Loop through all pages
while True:
    # Find all elements with class "auto product-index"
    elements = WebDriverWait(driver, 10).until(EC.presence_of_all_elements_located((By.XPATH, '//div[@data-aos="zoom-in"]')))

    # Loop over the elements and extract the product ID and text
    for element in elements:
        product_text = element.text
        print(product_text)

        # Extract SALE, discount, product, discounted_price, original_price, and size
        info = product_text.split("\n")
        print(info)

        try:
            sale = info[0]
            discount = info[1] if len(info) > 1 else None

            if len(info) > 2:
                product_size = info[2].split("|")
                product = product_size[0].strip()
                color = product_size[1].strip() if len(product_size) > 1 else None
            else:
                product = None
                color = None

            discounted_price = info[3] if len(info) > 3 else None
            original_price = info[4] if len(info) > 4 else None
            size = ", ".join(info[5:]) if len(info) >= 6 else None

            # Append product info to respective lists
            sales.append(sale)
            discounts.append(discount)
            products.append(product)
            discounted_prices.append(discounted_price)
            original_prices.append(original_price)
            sizes.append(size)
            colors.append(color)

        except IndexError:
            print("Error: Could not extract all product information")



    # Find the "Next" button, if it exists
    next_button = driver.find_elements_by_xpath('//a[@class="paginate_next"]')
    if len(next_button) == 0:
        # If the "Next" button does not exist, break out of the loop
        break
    else:
        # Click the "Next" button to go to the next page
        next_button[0].click()
        WebDriverWait(driver, 10).until(EC.staleness_of(elements[0]))
        scroll_down(driver)

# Combine the lists into a DataFrame
df = pd.DataFrame({'Sale': sales, 'Discount': discounts, 'Product': products, 'Color': colors, 'Discounted Price': discounted_prices, 'Original Price': original_prices, 'Size':sizes})

print(df)
df.to_csv('my_data.csv')
driver.quit()
