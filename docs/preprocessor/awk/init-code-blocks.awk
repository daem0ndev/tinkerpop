# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

#
# @author Daniel Kuppitz (http://gremlin.guru)
#
function capitalize(string) {
  return toupper(substr(string, 1, 1)) substr(string, 2)
}

BEGIN {
  delimiter = 0
}

/^pb\([0-9]*\); '\[gremlin-/ {
  delimiter = 1
  split($0, a, "-")
  b = gensub(/]'/, "", "g", a[2])
  split(b, c, ",")
  split(a[1], d, ";")
  lang = c[1]
  graph = c[2]
  print d[1] "; '[source," lang "]'"
  print "'+EVALUATED'"
  print "'+IGNORE'"
  if (graph) {
    print "graph = TinkerFactory.create" capitalize(graph) "()"
  } else {
    print "graph = TinkerGraph.open()"
  }
  print "g = graph.traversal()"
  print "marko = g.V().has('name', 'marko').tryNext().orElse(null)"
  print "f = new File('/tmp/neo4j')"
  print "if (f.exists()) f.deleteDir()"
  print "f = new File('/tmp/tinkergraph.kryo')"
  print "if (f.exists()) f.deleteDir()"
  print ":set max-iteration 100"
  if (lang == "python") {
    print "import org.apache.tinkerpop.gremlin.python.jsr223.PythonTranslator"
    print "import javax.script.ScriptEngineManager"
    print "import javax.script.SimpleBindings"
    print "jython = new org.apache.tinkerpop.gremlin.python.jsr223.GremlinJythonScriptEngine()"
    print "jython.eval('import sys')"
    # print "jython.eval('sys.path.append(\"" PYTHONPATH "\")')"
    print "jython.eval('sys.path.append(\"" TP_HOME "/gremlin-python/target/test-classes/Lib\")')"
    # print "jython.eval('sys.path.append(\"/Users/marko/software/tinkerpop/gremlin-python/target/test-classes/Lib\")')"
    print "jython.eval('from gremlin_python import statics')"
    print "jython.eval('from gremlin_python.process.graph_traversal import GraphTraversal')"
    print "jython.eval('from gremlin_python.process.graph_traversal import GraphTraversalSource')"
    print "jython.eval('from gremlin_python.process.graph_traversal import __')"
    # print "jython.eval('from gremlin_python.driver.websocket_remote_connection import WebSocketRemoteConnection')"
    print "jython.eval('from gremlin_python.structure.remote_graph import RemoteGraph')"
    print "jython.eval('from gremlin_python.process.traversal import Operator')"
    print "jython.eval('from gremlin_python.process.graphson import GraphSONWriter')"
    print "jython.eval('from gremlin_python.process.graphson import serializers')"
    print "jython.eval('from gremlin_python.process.traversal import Bytecode')"
    print "jython.eval('statics.load_statics(globals())')"
    print "jythonBindings = jython.createBindings()"
    print "jythonBindings.put('g', jython.eval('RemoteGraph(None).traversal()'))"
    print "jython.getContext().setBindings(jythonBindings, javax.script.ScriptContext.GLOBAL_SCOPE)"
    print "groovy = new org.apache.tinkerpop.gremlin.groovy.jsr223.GremlinGroovyScriptEngine()"
    print "groovyBindings = groovy.createBindings()"
    print "groovyBindings.put('g', g)"
    print "groovyBindings.put('TinkerGraphComputer', TinkerGraphComputer)"
    print "groovy.getContext().setBindings(groovyBindings, javax.script.ScriptContext.GLOBAL_SCOPE)"
  }
  print "'-IGNORE'"
}

!/^pb\([0-9]*\); '\[gremlin-/ {
  if (delimiter == 2 && !($0 ~ /^pb\([0-9]*\); '----'/)) {
    switch (lang) {
      case "python":
        print "jython.getContext().getBindings(javax.script.ScriptContext.GLOBAL_SCOPE).put('j',\"\"\"" gensub("\\('id',([0-9]+)\\)", "\\1", "g") "\"\"\")"
        print "groovy.getContext().getBindings(javax.script.ScriptContext.GLOBAL_SCOPE).put('j', jython.eval('GraphSONWriter.writeObject(j)').toString())"
        print "groovy.eval(groovy.eval('GroovyTranslator.of(\"g\").translate(GraphSONReader.build().create().mapper.readValue(j,Bytecode.class))').toString())"
        break
      default:
        print
        break
    }
  } else print
}

/^pb\([0-9]*\); '----'/ {
  if (delimiter == 1) delimiter = 2
  else if (delimiter == 2) {
    print "'-EVALUATED'"
    delimiter = 0
  }
}
