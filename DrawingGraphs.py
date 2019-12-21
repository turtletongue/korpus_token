import networkx as nx
import matplotlib.pyplot as plt
import gspread
from oauth2client.service_account import ServiceAccountCredentials
from google.colab import files 
base = []
def start_read_form():
  form = input()
  worksht = input()
  uploaded = files.upload()
  for fn in uploaded.keys():
    name = fn
    print('User uploaded file "{name}" with length {length} bytes'.format(name=name, length=len(uploaded[fn])))
  scope = ['https://spreadsheets.google.com/feeds','https://www.googleapis.com/auth/drive']
  credentials = ServiceAccountCredentials.from_json_keyfile_name("Korpus Token-616b37e6af5d.json", scope)
  gc = gspread.authorize(credentials)
  sh = gc.open(form)
  worksheet = sh.worksheet(worksht)
  line = 2
  while (worksheet.acell('B' + str(line)).value != ""):
    base.append((worksheet.acell('B' + str(line)).value, worksheet.acell('C' + str(line)).value))
    line += 1
def start_draw():
  g = nx.DiGraph()
  g.add_edges_from(base)
  nx.draw(g, with_labels=True, node_size=2000, arrows=True, arrowsize=15, edge_vmin="250", node_shape="o", edge_Color="black", node_color="yellow", font_color="black", font_size=8, horizontalalignment="center")
  plt.show()
  plt.savefig("graph.png")