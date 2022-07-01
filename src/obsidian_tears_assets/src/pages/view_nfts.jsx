import * as React from "react";
import { ReactPictureGrid } from "react-picture-grid";
import "../../assets/main.css";

const ViewNfts = (props) => {
  return (
    <div className="row">
      {props.data.map((url, i) => (
        <img src={url} key={i}/>
      ))}
    </div>
  );
};

export default ViewNfts;
