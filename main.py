from flask import Flask, render_template, url_for, request, session, redirect
from connect import contract
from flask import render_template, request

app = Flask(__name__)

app.secret_key = 'popanegra'
pk = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"

@app.route('/', methods=["GET", "POST"])
def index():
    return render_template('index.html')


@app.route("/reg", methods=["GET", "POST"])
def reg():
    if request.method == "POST":
        try:
            address = request.form.get("address")
            login = request.form.get("login")
            password = request.form.get("password")

            result = contract.functions.registr(
                login,
                password
            ).transact({"from": address})

            session["login"] = login

        except Exception as e:
            return f"Ошибка {e}"

        return redirect(url_for("index"))
    return render_template("reg.html")

@app.route("/authorization", methods=["GET", "POST"])
def authorization():

    if request.method =="POST":
        try:
            login = request.form.get("login")
            password = request.form.get("password")

            result = contract.functions.authorization(
                login,
                password
            ).transact({"from": pk})

            session["login"] = login

        except Exception as e:
            return f"Ошибка {e}"
        
        return redirect(url_for("index"))
    return render_template("authorization.html")


@app.route('/rr', methods=["GET", "POST"])
def rr():
    return render_template('rr.html')

@app.route('/addVodPrava', methods=["GET", "POST"])
def addVodPrava():
     
    if "login" not in session:
        return redirect(url_for("reg"))
     
    if request.method =="POST":
        try:
            number = int(request.form.get("number"))
            expiryDate = int(request.form.get("expiryDate"))
            category = request.form.get("category")
            issueDate = int(request.form.get("issueDate"))
            driver = request.form.get("driver")
            currentTime = int(request.form.get("currentTime"))
            result = contract.functions.addVodPrava(
                number,
                expiryDate,
                category,
                issueDate,
                driver,
                currentTime
            ).transact({"from": pk})

        except Exception as e:
            return f"Ошибка {e}"
        
        return redirect(url_for("rr"))
    return render_template("addVodPrava.html")


@app.route("/getVodPrava")
def getVodPrava():

    if "login" not in session:
        return redirect(url_for("reg"))

    try:
        result = contract.functions.getVodPrava().call({"from": pk})
        data = {
            "number": result[0],
            "expiryDate": result[1],
            "category": result[2],
            "issueDate": result[3],
            "driver": result[4],
            "currentTime": result[5]
        }

        return render_template("getVodPrava.html", data=data)

    except Exception as e:
        return f"Ошибка: {e}"


@app.route("/exit")
def exit():
    session.clear()
    return redirect("/")


if __name__ == "__main__":
    app.run(debug=True)
