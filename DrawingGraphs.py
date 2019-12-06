import networkx as nx
import pylab as plt
import gspread
from oauth2client.service_account import ServiceAccountCredentials 
base = []
def start_read_form():
  form = input()
  worksht = input()
  scope = ['https://spreadsheets.google.com/feeds','https://www.googleapis.com/auth/drive']
  credentials = ServiceAccountCredentials.from_json_keyfile_name("123.json", scope)
  gc = gspread.authorize(credentials)
  sh = gc.open(form)
  worksheet = sh.worksheet(worksht)
  line = 2
  while (worksheet.acell('B' + str(line)).value != ""):
    base.append(worksheet.acell('B' + str(line)).value + " " + worksheet.acell('C' + str(line)).value)
    base.append(worksheet.acell('B' + str(line)).value + " " + worksheet.acell('D' + str(line)).value)
    line += 1

def start_draw():
  g = nx.read_edgelist(base)
  nx.draw(nx.DiGraph(g), with_labels=True, node_size=200, edge_Color="black", node_color='yellow', font_color="b", font_size=8, horizontalalignment="center")
  plt.axis('off')
  plt.show()
  plt.savefig('graph.png')