import networkx as nx
import matplotlib.pyplot as plt
import gspread
from statistics import mode
edges_list = []
arrow_receivers = []
arrow_senders = []
labels_dict = {}
most_arrows = []
def start_read_form():
  form = ""
  worksht = ""
  credentials = ServiceAccountCredentials.from_json_keyfile_name("Korpus Token-616b37e6af5d.json", scope)
  gc = gspread.authorize(credentials)
  sh = gc.open(form)
  worksheet = sh.worksheet(worksht)
  line = 2
  while (worksheet.acell('B' + str(line)).value != ""):
    arrow_receivers.append(worksheet.acell('C' + str(line)).value)
    arrow_senders.append(worksheet.acell('B' + str(line)).value)
    edges_list.append((worksheet.acell('B' + str(line)).value, worksheet.acell('C' + str(line)).value))
    labels_dict.update({worksheet.acell('B' + str(line)).value: worksheet.acell('B' + str(line)).value})
    labels_dict.update({worksheet.acell('C' + str(line)).value: worksheet.acell('C' + str(line)).value})
    line += 1
def start_draw():
  g = nx.DiGraph()
  g.add_edges_from(edges_list)
  no_mode_nodes = arrow_receivers + arrow_senders
  try:
    most_arrows.append(mode(arrow_receivers))
    val = no_mode_nodes.count(most_arrows[0])
    for i in range(val):
      no_mode_nodes.remove(most_arrows[0])
      print(no_mode_nodes)
  except Exception:
      most_arrows.clear()
  print(most_arrows[0])
  print(no_mode_nodes)
  pos = nx.spring_layout(g)
  if most_arrows != []:
    nx.draw_networkx_nodes(g, pos, nodelist=most_arrows, with_labels=True, node_size=2000, node_color="blue", font_size=8, font_color="black", horizontalalignment="center")
  nx.draw_networkx_nodes(g, pos, nodelist=no_mode_nodes, with_labels=True, node_size=2000, node_color="yellow",  font_size=8, font_color="black", horizontalalignment="center")
  nx.draw_networkx_edges(g, pos, edgelist=edges_list, edge_vmin=500, with_labels=True, node_size=2000)
  nx.draw_networkx_labels(g, pos, nodelist=edges_list, with_labels=True, node_size=2000, font_size=8, font_color="black", horizontalalignment="center")
  plt.show()
  plt.savefig("graph.png")
start_read_form()
start_draw()