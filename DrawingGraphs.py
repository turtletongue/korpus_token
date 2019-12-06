import networkx as nx
import os
import pylab as plt
from google.colab import files 
def start():
  uploaded = files.upload()
  for fn in uploaded.keys():
    name = fn
    print('User uploaded file "{name}" with length {length} bytes'.format(name=name, length=len(uploaded[fn])))
  with open(name, "r", encoding="utf-8-sig") as file:
    base = file.readlines()
  for i in range(len(str_list)):
    base[i] = base[i].rstrip("\n")
  g = nx.read_edgelist(base)
  nx.draw(nx.DiGraph(g), with_labels=True, node_size=200, edge_Color="black", node_color='yellow', font_color="b", font_size=8, horizontalalignment="center")
  plt.axis('off')
  plt.show()
  plt.savefig('graph.png')